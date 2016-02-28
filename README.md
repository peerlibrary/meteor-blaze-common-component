Common Component
================

An alternative base [Blaze Component](https://github.com/peerlibrary/meteor-blaze-components)
extended with common features.

Adding this package to your [Meteor](http://www.meteor.com/) application adds `CommonComponent` and
`CommonMixin` classes into the global scope.

**Pull requests with new features are more than encouraged.** Let us all combine our common practices and
patterns together. We can always split it later into smaller packages.

Both client and server side.

Installation
------------

```
meteor add peerlibrary:blaze-common-component
```

Usage
-----

This package simply supersedes [Blaze Components](https://github.com/peerlibrary/meteor-blaze-components)
package. Instead of using Blaze Components package, replace it with a dependency on this package.

Then, use `CommonComponent` as a base class for your components and `CommonMixin` for your mixins.

See [code itself](https://github.com/peerlibrary/meteor-blaze-common-component/blob/master/base.coffee) for
documentation of available features in code comments.
