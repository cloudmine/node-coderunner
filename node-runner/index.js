var Hapi = require('hapi');
var Good = require('good');
var server = new Hapi.Server(3000);

var snippets = getSnippets(require('cm-user-snippets'));

function getSnippets(snippets){
  var ret = {
    names: function(){
      return Object.keys(snippets)
    },
    snippets: function(){
      for(var name in snippets){
        var s = snippets[name];
        if(typeof s == 'function'){
          s = snippets[name] = {
            type: "standalone",
            handler: s
          }
        } else if (!s.type){
          s.type = "standalone";
        }
      }

      return snippets;
    },
    get: function(name){
      var snippet = ret.snippets()[name];

      if(snippet && typeof snippet.handler == "function"){
        return snippet;
      }
      return null;
    },
    validate: function(){
      var errors = {};
      for(var name in ret.snippets()){
        if(typeof snippets[name].handler != "function"){
          errors[name] = "Handler for '" + name + "' is not a function";
        }
      }
      return errors;
    }
  }

  return ret;
}

server.route({
  method: ['PUT', 'POST', 'GET'],
  path: '/snippet/{name}',
  handler: function (request, reply) {

    var req = {
      // todo: fill in request info here

    }

    var res = {
      reply: function(data){
        reply({result: data});
      }
    }

    var name = request.params.name;
    var snippet = snippets.get(name);

    server.log("info", "got request for snippet " + name);

    if(snippet){
      server.log("info", "snippet " + name + " found");

      try {
        snippet.handler(req, res);
      } catch(e){
        reply({error: "Uncaught Exception: " + e.message, details: JSON.stringify(e)}).code(400);
      }
    } else {
      if(!snippet){
        server.log("error", "snippet " + name + " is not found");
        reply({error: "Snippet not found: " + name}).code(400);
      } else {
        server.log("error", "snippet " + name + " is not a function");
        reply({error: "Snippet export is not a function"}).code(400);
      }
    }

    function reply_error(message, details){
      reply({error: "Snippet not found: " + name}).code(400);
    }
  }
});

server.route({
  method: "GET",
  path: '/names',
  handler: function(request, reply){
    reply(snippets.names());
  }
});

server.route({
  method: "GET",
  path: '/validate',
  handler: function(request, reply){
    var errors = snippets.validate()
    if(Object.keys(errors).length == 0){
      reply();
    }
    else {
      reply(errors).code(400);
    }
  }
});

server.pack.register({
    plugin: Good,
    options: {
        reporters: [{
            reporter: require('good-console'),
            args:[{ log: '*', request: '*' }]
        }]
    }
}, function (err) {
    if (err) {
        throw err; // something bad happened loading the plugin
    }

   start();
});

function start(){
  server.start(function () {
    server.log('Server running at:', server.info.uri);
  });
}
