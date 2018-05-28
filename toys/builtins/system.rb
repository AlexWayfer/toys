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

desc "A set of system commands for Toys"

long_desc "Contains tools that inspect, configure, and update Toys itself."

tool "version" do
  desc "Print the current Toys version"

  def run
    puts ::Toys::VERSION
  end
end

tool "update" do
  desc "Update Toys if a newer version is available"

  long_desc "Checks rubygems for a newer version of Toys. If one is available, downloads" \
            " and installs it."

  flag :yes, "-y", "--yes", desc: "Do not ask for interactive confirmation"

  include :exec
  include :highline

  def run
    logger.info "Checking rubygems for the latest Toys release..."
    if capture("gem query -q -r -e toys") =~ /toys\s\((.+)\)/
      latest_version = ::Gem::Version.new($1)
      cur_version = ::Gem::Version.new(::Toys::VERSION)
      if latest_version > cur_version
        exit(1) unless option(:yes) ||
                       agree("Update toys from #{cur_version} to #{latest_version}? (y/n) ")
        sh("gem install toys")
      elsif latest_version < cur_version
        logger.warn("Toys is already at experimental version #{cur_version}, which is later than" \
                    " the latest released version #{latest_version}")
      else
        logger.warn("Toys is already at the latest version: #{latest_version}")
      end
    else
      logger.error("Could not get latest Toys version")
      exit(1)
    end
  end
end
