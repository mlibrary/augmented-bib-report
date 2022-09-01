class WorldCatClient
  def initialize
    @conn = Faraday.new(
      url: "http://worldcat.org"
    ) do |f|
      f.response :logger, nil, {headers: true, bodies: true}
      f.request :json
      #  f.request :retry, {max: 1, retry_statuses: [500]}
      f.response :json
    end
  end

  def libraries_for_oclc_nums(oclc_nums = [])
    oclc_nums.map { |x| libraries_for_oclc_num(x) }.flatten.uniq
  end

  def libraries_for_oclc_num(oclc)
    query = {
      maximumLibraries: 50,
      wskey: ENV.fetch("WORLDCAT_API_KEY"),
      format: "json"
    }
    resp = @conn.public_send(:get, "/webservices/catalog/content/libraries/#{oclc}", query)
    JSON.parse(resp.body)&.dig("library")&.map do |x|
      {country: x["country"], oclcSymbol: x["oclcSymbol"]}
    end || []
  end
end
