class FilmsController < ApplicationController

    def index
        if params['genre'].present?
            render json: Film.get_random_film(params['genre'])
        else
            render json: Film.get_random_film()
        end
    end

    def twilio
        if params['genre'].present?
            render xml: Film.twiml(params['genre'])
        else
            render xml: Film.twiml()
        end
    end

end