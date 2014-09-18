var controllers = {};

controllers.index = function(req, res, next){
  res.write('core.index');
  res.end();
};

module.exports = controllers;
