require 'facter'
require 'facterdb'
require 'json'
require 'pp'

include FacterDB

module RspecPuppetFacts

  def on_supported_os( opts = {} )
    opts[:hardwaremodels] ||= ['x86_64']
    opts[:supported_os] ||= RspecPuppetFacts.meta_supported_os

    oses_facts = FacterDB::get_os_facts

    p opts[:supported_os].map { |os_sup| os_sup['operatingsystem'] }

    h = {}

    oses_facts.select do |os_facts|
      opts[:supported_os].each do |os_sup|
        if os_sup['operatingsystemrelease']
          h["#{os_facts[:operatingsystem].downcase}-#{os_facts[:operatingsystemmajrelease].split(" ")[0]}-#{os_facts[:hardwaremodel]}"] = os_facts if Facter.version[0..2] == os_facts[:facterversion][0..2] and
            opts[:hardwaremodels].include?(os_facts[:hardwaremodel]) and
            os_sup['operatingsystem'] == os_facts[:operatingsystem] and
            os_sup['operatingsystemrelease'].include?(os_facts[:operatingsystemmajrelease])
        else
          h["#{os_facts[:operatingsystem].downcase}-#{os_facts[:hardwaremodel]}"] = os_facts if 
          Facter.version[0..2] == os_facts[:facterversion][0..2] and
            opts[:hardwaremodels].include?(os_facts[:hardwaremodel]) and
            os_facts[:operatingsystem] == os_sup['operatingsystem']
        end
      end
    end

    h
  end

  # @api private
  def self.meta_supported_os
    @meta_supported_os ||= get_meta_supported_os
  end

  # @api private
  def self.get_meta_supported_os
    metadata = get_metadata
    if metadata['operatingsystem_support'].nil?
      fail StandardError, "Unknown operatingsystem support"
    end
    metadata['operatingsystem_support']
  end

  # @api private
  def self.get_metadata
    if ! File.file?('metadata.json')
      fail StandardError, "Can't find metadata.json... dunno why"
    end
    JSON.parse(File.read('metadata.json'))
  end
end
