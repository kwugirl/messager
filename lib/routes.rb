Routes = Rack::Builder.new do
  run Endpoints::Messages
end
