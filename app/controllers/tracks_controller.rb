class TracksController < ApplicationController

  def search
    tracks = RSpotify::Track.search(search_params[:track], limit: 8, market: "US")
    if tracks.length > 0
      tracks_filtered = []
      tracks.each do |track|
        tracks_filtered.push({
          name: track.name,
          image: track.album.images[0],
          artist: track.artists,
          urls: track.external_urls,
          id: track.id
          })
      end
      render json: {tracks: tracks_filtered}, status: 200
    else
      render json: {message: "No results found. Please try changing your search"}, status: 200
    end
  end

  def features
    track = RSpotify::Track.find(features_params[:id])
    features = track.audio_features
    render json: {features: features}, status: 200
  end

  def lyrics
    songs = []
    genius_data = RestClient.get("https://api.genius.com/search?q=#{lyrics_params[:lyrics]}", headers={
      "Authorization":"Bearer #{ENV["GENIUS_CLIENT"]}"
      })
    genius_parsed = JSON.parse(genius_data)
    if genius_parsed["response"]["hits"].length > 0
      genius_parsed["response"]["hits"].each do |hit|
        if hit["type"] == "song"
          songs.push({
              title: hit["result"]["title"],
              artist: hit["result"]["primary_artist"]["name"],
              lyrics_url: hit["result"]["url"]
            })
        end
      end
      if songs.length > 5
        songs.slice!(5, songs.length)
      end
      spotify_data_filtered = []
      songs.each do |song|
        spotify_data = RSpotify::Track.search(song[:title], limit: 5, market: "US")
        if spotify_data.length > 0
          spotify_data.each do |track|
            song_title = song[:title].downcase.gsub!(/\s*/, "")
            song_title.strip!
            song_title.gsub!(/-|\(|\.|\)|'|,|"|’/, "")
            song_title.gsub!(/\s*/, "")
            track_title = track.name.downcase.gsub!(/\s*/, "")
            track_title.strip!
            track_title.gsub!(/-|\(|\.|\)|'|,|"|’/, "")
            track_title.gsub!(/\s*/, "")
            artist_name = song[:artist].downcase.gsub!(/\s*/, "")
            artist_name.strip!
            sp_artist_name = track.artists[0].name.downcase.gsub!(/\s*/, "")
            sp_artist_name.strip!
            if track_title == song_title && artist_name == sp_artist_name
              spotify_data_filtered.push({
                name: track.name,
                image: track.album.images[0],
                artist: track.artists,
                urls: track.external_urls,
                id: track.id,
                lyrics_url: song[:lyrics_url]
                })
            else
              i = 0
              j = 0
              song_running_total = 0
              artist_running_total = 0
              until i == song_title.length do
                if track_title.include? song_title[i]
                  song_running_total += 1
                end
                i += 1
              end
              until j == artist_name.length do
                if sp_artist_name.include? artist_name[j]
                  artist_running_total += 1
                end
                j += 1
              end
              # puts "genius song: #{song_title}, spotify song: #{track_title}"
              # puts "song calc: #{song_running_total / song_title.length.to_f}"
              # puts "genius artist: #{artist_name}, spotify artist: #{sp_artist_name}"
              # puts "artist calc: #{artist_running_total / artist_name.length.to_f}"
              song_match = song_running_total / song_title.length.to_f
              artist_match = artist_running_total / artist_name.length.to_f
              if song_match >= 0.9 && artist_match >= 0.85
                spotify_data_filtered.push({
                  name: track.name,
                  image: track.album.images[0],
                  artist: track.artists,
                  urls: track.external_urls,
                  id: track.id,
                  lyrics_url: song[:lyrics_url]
                  })
              end
            end
          end
        end
      end
      if spotify_data_filtered.length > 0
        render json: {tracks: spotify_data_filtered}, status: 200
      else
        render json: {message: "No results found. Please try changing your search"}, status: 200
      end
    else
      render json: {message: "No results found. Please try changing your search"}, status: 200
    end
    rescue URI::InvalidURIError
      render json: {message: "No results found. Please try changing your search"}, status: 200
  end

  private
  def search_params
    params.permit(:track)
  end
  def features_params
    params.permit(:id)
  end
  def lyrics_params
    params.permit(:lyrics)
  end
end
