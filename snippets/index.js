module.exports = {
  "test": {
    type: "standalone", // save, saved, login, loggedin, logout, loggedout, search, searched, get, got
    handler: require('./test')
  },
  "bad": function(req, res){
    "asdf".hi();
  },
  "broken": "hi"
}
