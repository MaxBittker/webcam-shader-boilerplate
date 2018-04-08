
Bottom Tip(an at-bottom message tip)
----

Note: you have to maintain logs manually with this module.

Prototype https://youtu.be/wjLxXS0CV4k

I intented to replace [webpack-hud][hud] with it
but it turned out to be not as useful as webpack-hud
since messages from Webpack is quite messy. 

[hud]: https://github.com/mvc-works/webpack-hud

### Usage

```bash
npm i --save-dev bottom-tip
```

```js
import render from 'bottom-tip'

var targetElement = document.createElement('div')
document.body.append(targetElement)
render(targetElement, 'warn', 'some warning message')
setTimeout(function(){
  render(targetElement, 'inactive')
}, 2000)
```

Types:

* `inactive`
* `ok`
* `warn`
* `error`

### Develop

Code for DOM rendering look strange. It's written in [diffhtml][diffhtml].

[diffhtml]: https://github.com/tbranyen/diffhtml/issues/65#issuecomment-220238716

Try this project:

```bash
webpack-dev-server --hot
# open http://localhost:8080
```

### License

MIT
