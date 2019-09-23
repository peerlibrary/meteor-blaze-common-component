Package.describe({
  name: 'peerlibrary:blaze-common-component',
  summary: "An extended base Blaze Component with common features",
  version: '0.5.0',
  git: 'https://github.com/peerlibrary/meteor-blaze-common-component.git'
});

Package.onUse(function (api) {
  api.versionsFrom('1.8.1');

  // Core dependencies.
  api.use([
    'coffeescript@2.4.1',
    'underscore',
    'spacebars@1.0.15',
    'tracker'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:blaze-components@0.23.0',
    'momentjs:moment@2.24.0',
    'peerlibrary:assert@0.3.0'
  ]);

  // Optional dependencies.
  api.use([
    'peerlibrary:flow-router@2.12.1_1',
    'kadira:flow-router@2.12.1',
    'peerlibrary:user-extra@0.5.0'
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
  api.versionsFrom('1.8.1');

  // Core dependencies.
  api.use([
    'coffeescript@2.4.1',
    'jquery@1.11.11',
    'tracker'
  ]);

  // Internal dependencies.
  api.use([
    'peerlibrary:blaze-common-component',
    'peerlibrary:blaze-components@0.23.0'
  ]);

  // 3rd party dependencies.
  api.use([
    'peerlibrary:classy-test@0.4.0'
  ]);

  api.addFiles([
    'tests.html',
    'tests.coffee',
    'tests.css'
   ]);
});
