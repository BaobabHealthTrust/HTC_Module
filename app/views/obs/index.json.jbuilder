json.array!(@obs) do |ob|
  json.extract! ob, :id
  json.url ob_url(ob, format: :json)
end
