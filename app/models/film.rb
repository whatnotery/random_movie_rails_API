class Film < ApplicationRecord
    require 'http'
    require 'twilio-ruby'

    def self.get_latest_film_id
        response = HTTP.get('https://api.themoviedb.org/3/movie/latest', :params => {:api_key => ENV['MOVIE_DB_API_KEY']
            })
        response.parse['id'] if response.status == 200
    end

    def self.get_random_film(*genre)
        movie_id = rand(get_latest_film_id);
        response = HTTP.get("https://api.themoviedb.org/3/movie/#{movie_id}", :params => {:api_key => ENV['MOVIE_DB_API_KEY']})
        data = response.parse if response.status == 200
        if !genre.empty?
            if !data['genres'].empty? and data['genres'][0]['name'] == genre[0].capitalize and data["adult"] == false or !data['title'].blank? or !data['poster_path'].blank? or !data['overview'].nil? or !data['tagline'].nil?  
                data
            else
                get_random_film(genre[0].capitalize) 
            end
        else
            get_random_film()
        end
    end

    def self.twiml(*params)
        if params.empty?
            data = Film.get_random_film()
        else
            data = Film.get_random_film(params)
        end
        poster = "https://image.tmdb.org/t/p/w300/'#{data['poster_path']}"
        imdb = "https://www.imdb.com/title/#{data['imdb_id']}"
        twiml = Twilio::TwiML::MessagingResponse.new do |r|
            r.message body: "#{data['title']} (#{data['release_date'].slice(0, 4)}) [#{data['genres'][0]['name']}] \n -------- \n #{data['overview']}"
            r.message body: imdb
        end
    end
end
