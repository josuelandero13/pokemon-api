class PokemonResponse
  attr_reader :origin, :response

  def initialize(origin:, response:)
    @origin = origin
    @response = response
    @pokemon_body = pokemon_body
  end

  def pokemon_body
    {
      'origin': origin,
      'name': response.body["name"],
      'weight': response.body["weight"],
      'types': type(response.body["types"]),
      'stats': stats(response.body["stats"]),
      'consulted_at': response.body["consulted_at"]
    }
  end

  def status
    response.status
  end

  private

  def stats(stats)
    stats.each_with_object([]) do |stat, array|
      array << "#{stat.dig('stat', 'name')}: #{stat['base_stat']}"
    end
  end

  def type(types)
    types = types.map { |type| type.dig("type", "name") }
  end
end
