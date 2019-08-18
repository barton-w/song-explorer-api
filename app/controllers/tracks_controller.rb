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

  private
  def search_params
    params.permit(:track)
  end
  def features_params
    params.permit(:id)
  end
end
