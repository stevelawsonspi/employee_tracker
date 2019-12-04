require "google/cloud/datastore"

datastore  = Google::Cloud::Datastore.new(project: "sporting-chance")
candidates = datastore.run(datastore.query("AuctionCandidate").where('visible', '=', true), namespace: nil) # namespace = [default]
candidates = datastore.run(datastore.query("AuctionCandidate").where('visible', '=', true), namespace: "joeysDev")
c = @candidates.first
c.properties.to_hash
c['name'] # get record property

def new_candidate(datastore)
  candidate     = Google::Cloud::Datastore::Entity.new
  candidate.key = Google::Cloud::Datastore::Key.new "AuctionCandidate"
  candidate.key.namespace  = "joeysDev"
  candidate['image_uri']   = 'https://storage.googleapis.com/sporting-chance.appspot.com/auction-data/potato.jpg'
  candidate['auction_id']  = nil
  candidate['name']        = 'Potato Dude'
  candidate['description'] = 'Humble guy, often baked :)'
  candidate['handicap']    = 40
  candidate['visible']     = true
  datastore.save candidate
  candidate
end
c = new_candidate(datastore)
c.key.id # auto generated
c.key.namespace