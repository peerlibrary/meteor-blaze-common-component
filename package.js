Package.describe({
  name: 'peerlibrary:blaze-common-component',
  summary: "An extended base Blaze Component with common features",
  version: '0.2.0',
  git: 'https://github.com/peerlibrary/meteor-blaze-common-component.git'
});

Package.onUse(function (api) {
  api.versionsFrom('1.2.0.2');

  // Core dependencies.
  api.use([
    'coffeescript',
    'underscore',
    'spacebars',
    'tracker'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:blaze-components@0.18.0',
    'momentjs:moment@2.11.2',
    'peerlibrary:assert@0.2.5'
  ]);

  // Optional dependencies.
  api.use([
    'peerlibrary:flow-router@2.10.1_1',
    'kadira:flow-router@2.10.1',
    'peerlibrary:user-extra@0.1.0'
  ], {weak: true});

  api.export('CommonComponent');
  api.export('CommonMixin');

  api.addFiles([
    'base.coffee',
    'component.coffee',
    'mixin.coffee'
  ]);
});

Package.onTest(function (api) {
  // Core dependencies.
  api.use([
    'coffeescript',
    'jquery',
    'tracker'
  ]);

  // Internal dependencies.
  api.use([
    'peerlibrary:blaze-common-component',
    'peerlibrary:blaze-components@0.18.0'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:classy-test@0.2.24'
  ]);

  api.addFiles([
    'tests.html',
    'tests.coffee',
    'tests.css'
   ]);
});
