class WorldCatSummary
  def self.for(oclc_numbers)
    new(WorldCatClient.new.libraries_for_oclc_nums(oclc_numbers))
  end

  def initialize(data)
    @data = data # output from #libraries_for_oclc_nums method in WorldCatClient
  end

  def total_libraries
    @data.count
  end

  def united_states_libraries
    @data.filter_map { |x| x[:oclcSymbol] if x[:country] == "United States" }
  end

  def non_united_states_libraries
    @data.filter_map { |x| x[:oclcSymbol] if x[:country] != "United States" }
  end

  def total_btaa_members
  end

  def total_independent_um_libraries
  end
end
