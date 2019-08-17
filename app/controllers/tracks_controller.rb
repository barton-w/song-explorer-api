class TracksController < ApplicationController
  def search
    tracks_filtered = []
    tracks = RSpotify::Track.search(params[:track], limit: 10, market: "US")
    tracks.each do |track|
      audio_features = track.audio_features
      tracks_filtered.push({
        name: track.name,
        image: track.album.images[0],
        artist: track.artists,
        id: track.id,
        audio_features: audio_features
        })
    end
    render json: {tracks: tracks_filtered}, status: 200
  end
  def features
    track = RSpotify::Track.find(params[:id])
    features = track.audio_features
    render json: {features: features}, status: 200
  end
end
