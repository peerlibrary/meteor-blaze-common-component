Package.describe({
  name: 'peerlibrary:blaze-common-component',
  summary: "An extended base Blaze Component with common features",
  version: '0.1.0',
  git: 'https://github.com/peerlibrary/meteor-blaze-common-component.git'
});

Package.onUse(function (api) {
  api.versionsFrom('1.2.0.2');

  // Core dependencies.
  api.use([
    'coffeescript',
    'underscore-extra',
    'spacebars',
    'tracker'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:blaze-components@0.16.2',
    'momentjs:moment@2.11.2',
    'peerlibrary:assert@0.2.5'
  ]);

  // Optional dependencies.
  api.use([
    'peerlibrary:flow-router@2.10.1_1',
    'kadira:flow-router@2.10.1'
  ], {weak: true});

  api.imply([
    'peerlibrary:blaze-components'
  ]);

  api.export('CommonComponent');
  api.export('CommonMixin');

  api.addFiles([
    'base.coffee'
  ]);
});
