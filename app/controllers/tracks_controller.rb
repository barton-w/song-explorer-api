class TracksController < ApplicationController

  def search
    tracks = RSpotify::Track.search(search_params[:track], limit: 5, market: "US")
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
            song_title.gsub!(/-|\(|\.|\)|'|,|"|’/, "")
            song_title.gsub!(/\s*/, "")
            track_title = track.name.downcase.gsub!(/\s*/, "")
            track_title.gsub!(/-|\(|\.|\)|'|,|"|’/, "")
            track_title.gsub!(/\s*/, "")
            artist_name = song[:artist].downcase.gsub!(/\s*/, "")
            sp_artist_name = track.artists[0].name.downcase.gsub!(/\s*/, "")
            pp "Lyrics song is: #{song_title} by #{artist_name} and Spotify track is #{track_title} by #{sp_artist_name}"
            if track_title == song_title && artist_name == sp_artist_name
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
      render json: {tracks: spotify_data_filtered}, status: 200
    else
      render json: {message: "No results found. Please try changing your search"}, status: 200
    end
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
