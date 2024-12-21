class PokemonProxy
  EXPIRATION = 24.hours.freeze

  attr_reader :client, :cache

  def initialize(client)
    @client = client
    @cache = Rails.cache
  end

  def get_pokemon(pokemon_name:)
    return pokemon_response("on_cache", cache.read("pokemon_cached/#{pokemon_name}")) if cache.exist?("pokemon_cached/#{pokemon_name}")

    response = client.get_pokemon(pokemon_name:)
    if response.status == 200
      response.body["consulted_at"] = consulted_at
      cache.write("pokemon_cached/#{pokemon_name}", response, expires_in: EXPIRATION)
      pokemon_response("client_call", response)
    else
      pokemon_error_response(response)
    end
  end

  private

  def consulted_at
    Time.now.utc.strftime("%FT%T")
  end

  def pokemon_response(origin, response)
    {
      'origin': origin,
      'name': response.body["name"],
      'weight': response.body["weight"],
      'types': type(response.body["types"]),
      'stats': stats(response.body["stats"]),
      'consulted_at': response.body["consulted_at"]
    }
  end

  def stats(stats)
    stats.each_with_object([]) do |stat, array|
      array << "#{stat.dig('stat', 'name')}: #{stat['base_stat']}"
    end
  end

  def type(types)
    types.map { |type| type.dig("type", "name") }
  end

  def pokemon_error_response(response)
    {
      'error': response.body,
      'status': response.status
    }
  end
end
