json.array!(@htcs) do |htc|
  json.extract! htc, :id
  json.url htc_url(htc, format: :json)
end
