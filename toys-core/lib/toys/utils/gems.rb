# frozen_string_literal: true

# Copyright 2018 Daniel Azuma
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the copyright holder, nor the names of any other
#   contributors to this software, may be used to endorse or promote products
#   derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
;

module Toys
  module Utils
    ##
    # A helper module that activates and installs gems
    #
    class Gems
      ##
      # Failed to activate a gem.
      #
      class ActivationFailedError < ::StandardError
      end

      ##
      # Failed to install a gem.
      #
      class InstallFailedError < ActivationFailedError
      end

      ##
      # Need to add a gem to the bundle.
      #
      class GemfileUpdateNeededError < ActivationFailedError
        def initialize(requirements_text, gemfile_path)
          super("Required gem not available in the bundle: #{requirements_text}.\n" \
                "Please update your Gemfile #{gemfile_path.inspect}.")
        end
      end

      ##
      # Activate the given gem.
      #
      # @param [String] name Name of the gem
      # @param [String...] requirements Version requirements
      # @param [Boolean] suppress_confirm Suppress the confirmation prompt and just use the given
      #     `default_confirm` value.
      # @param [Boolean] default_confirm Default response for the confirmation prompt
      #
      def self.activate(name, *requirements, suppress_confirm: nil, default_confirm: nil)
        new.activate(name, *requirements,
                     suppress_confirm: suppress_confirm,
                     default_confirm: default_confirm)
      end

      ##
      # Create a new gem activator.
      #
      # @param [IO] input Input IO
      # @param [IO] output Output IO
      # @param [Boolean] suppress_confirm Suppress the confirmation prompt and just use the given
      #     `default_confirm` value.
      # @param [Boolean] default_confirm Default response for the confirmation prompt
      #
      def initialize(input: $stdin,
                     output: $stderr,
                     suppress_confirm: false,
                     default_confirm: true)
        @terminal = Terminal.new(input: input, output: output)
        @exec = Exec.new
        @suppress_confirm = suppress_confirm ? true : false
        @default_confirm = default_confirm ? true : false
      end

      ##
      # Activate the given gem. If it is not present, attempt to install it (or
      # inform the user to update the bundle).
      #
      # @param [String] name Name of the gem
      # @param [String...] requirements Version requirements
      # @param [Boolean] suppress_confirm Suppress the confirmation prompt and just use the given
      #     `default_confirm` value.
      # @param [Boolean] default_confirm Default response for the confirmation prompt
      #
      def activate(name, *requirements, suppress_confirm: nil, default_confirm: nil)
        suppress_confirm = suppress_confirm.nil? ? @suppress_confirm : suppress_confirm
        default_confirm = default_confirm.nil? ? @default_confirm : default_confirm
        gem(name, *requirements)
      rescue ::Gem::MissingSpecError
        install_gem(name, requirements, suppress_confirm, default_confirm)
      rescue ::Gem::LoadError => e
        if ::ENV["BUNDLE_GEMFILE"]
          raise GemfileUpdateNeededError.new(gem_requirements_text(name, requirements),
                                             ::ENV["BUNDLE_GEMFILE"])
        end
        raise ActivationFailedError, e.message
      end

      private

      def gem_requirements_text(name, requirements)
        "#{name.inspect}, #{requirements.map(&:inspect).join(', ')}"
      end

      def install_gem(name, requirements, suppress_confirm, default_confirm)
        requirements_text = gem_requirements_text(name, requirements)
        response =
          if suppress_confirm
            default_confirm
          else
            @terminal.confirm("Gem needed: #{requirements_text}. Install?",
                              default: default_confirm)
          end
        unless response
          raise InstallFailedError, "Canceled installation of needed gem: #{requirements_text}"
        end
        version = find_best_version(name, requirements)
        raise InstallFailedError, "No gem found matching #{requirements_text}." unless version
        perform_install(name, version)
        activate(name, *requirements)
      end

      def find_best_version(name, requirements)
        @terminal.spinner(leading_text: "Getting info on gem #{name.inspect}... ",
                          final_text: "Done.\n") do
          req = ::Gem::Requirement.new(*requirements)
          result = @exec.capture(["gem", "query", "-q", "-r", "-a", "-e", name])
          if result =~ /\(([\w\.,\s]+)\)/
            $1.split(", ")
              .map { |v| ::Gem::Version.new(v) }
              .find { |v| !v.prerelease? && req.satisfied_by?(v) }
          else
            raise InstallFailedError, "Unable to determine existing versions of gem #{name.inspect}"
          end
        end
      end

      def perform_install(name, version)
        @terminal.spinner(leading_text: "Installing gem #{name} #{version}... ",
                          final_text: "Done.\n") do
          result = @exec.exec(["gem", "install", name, "--version", version.to_s],
                              out: :capture, err: :capture)
          if result.error?
            @terminal.puts(result.captured_out + result.captured_err)
            raise InstallFailedError, "Failed to install gem #{name} #{version}"
          end
        end
      end
    end
  end
end
