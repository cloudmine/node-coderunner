# Node Code-Runner

This package provides the raw interface for CloudMine's Javascript Server Snippets.

**Unless you are looking to modify this directly and submit a pull request, you are most likely looking for our local [CLI testing tool](https://github.com/cloudmine/node-snippet-base).**

# Usage #

Install the package as a dependency

```
npm install cloudmine-servercode --save
```

Once installed, you can write your code normally. With this library, you can install any module you want, as long as it's in your `package.json` file.

Once your snippets are written, you will have to start to the CloudMine code-runner. The code-runner automatically fields requests to your code, and will call the appropriate snippet.

To start the coderunner, do:

```js

var CloudMineNode = require('cloudmine-servercode');

CloudMineNode.start(module, './index.js', function(err) {
  console.log('Server Started?', err);
});

```

`.start` takes two parameters:
1) The current `module`  
2) A path to a file, and expects to get a Node.js file that has exported modules in the form of an object. Each module key will be used as the name of the snippet (and is required), and the value should be of the form: `function(req, reply)`.

Reply is the method completion handler. You should call `reply(anything)` to finish the method and return `anything`.

## Example ##

To see this fully in action, we have a snippet base setup [here](https://github.com/cloudmine/node-snippet-base). You can fork or clone the example and see how it works. Right out of the box you can deploy it to CloudMine and run the snippet.

## Technical Details ##

When you call `.start`, the CloudMine Code Runner is creating an HTTP server that will handle requests for your application automatically. This server is started on port `4545`, so you should not use that port.

When you execute the snippet from CloudMine, the HTTP request is forwarded to your snippet. We use [Hapi](http://hapijs.com/) to handle the request. Rather than pass in a subset of functionality, we send your snippet the entire Request object ([docs](http://hapijs.com/api/#request-object)). The reply interface is also the same, ([docs](http://hapijs.com/api/#reply-interface)), which means anything you can pass back to Hapi you can pass back here.

## Upgrading ##

Each version of `cloudmine-node` will lockdown the version of Hapi, so you can be sure the interface won't change underneath you. However, Hapi [moves](https://github.com/hapijs/hapi/issues?q=label%3A%22release+notes%22) very quickly, and future versions may break your application, so upgrade carefully. This project follows [Semantic Versioning](http://semver.org/), so upgrades to Hapi that are not back backwards compatible will also result in a major version incrementing.
