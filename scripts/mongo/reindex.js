db.getCollectionNames().forEach(function(collName) {
  var coll = db.getCollection(collName);
  coll.reIndex();
});
