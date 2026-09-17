'use strict';

/**
 * Mini-routeur HTTP générique (Node.js pur).
 * Support : /livres, /livres/:id, montage de sous-routeurs.
 */
class Router {
  constructor() {
    this.routes = [];
  }

  add(method, path, ...handlers) {
    const keys = [];
    const pattern = new RegExp(
      '^' +
        path
          .replace(/\//g, '\\/')
          .replace(/:([A-Za-z_][A-Za-z0-9_]*)/g, (_, key) => {
            keys.push(key);
            return '([^/]+)';
          }) +
        '$'
    );

    this.routes.push({
      method: method.toUpperCase(),
      pattern,
      keys,
      handlers,
    });
  }

  get(path, ...handlers) {
    this.add('GET', path, ...handlers);
  }

  post(path, ...handlers) {
    this.add('POST', path, ...handlers);
  }

  put(path, ...handlers) {
    this.add('PUT', path, ...handlers);
  }

  patch(path, ...handlers) {
    this.add('PATCH', path, ...handlers);
  }

  delete(path, ...handlers) {
    this.add('DELETE', path, ...handlers);
  }

  /**
   * Monte un sous-routeur sous un préfixe.
   * Middlewares optionnels : use('/api/x', deviceKey, childRouter)
   */
  use(prefix, ...args) {
    const child = args[args.length - 1];
    const middlewares = args.slice(0, -1);
    const normalizedPrefix = prefix.replace(/\/+$/, '') || '';

    for (const route of child.routes) {
      const keys = [...route.keys];
      let childSource = route.pattern.source.replace(/^\^/, '').replace(/\$$/, '');

      if (childSource === '\\/') {
        childSource = '';
      }

      const prefixPattern = normalizedPrefix
        .replace(/\//g, '\\/')
        .replace(/:([A-Za-z_][A-Za-z0-9_]*)/g, (_, key) => {
          keys.unshift(key);
          return '([^/]+)';
        });

      this.routes.push({
        method: route.method,
        pattern: new RegExp('^' + prefixPattern + childSource + '$'),
        keys,
        handlers: [...middlewares, ...route.handlers],
      });
    }
  }

  async handle(req, res) {
    const url = new URL(req.url || '/', `http://${req.headers.host || 'localhost'}`);
    const pathname = url.pathname.replace(/\/+$/, '') || '/';
    const method = (req.method || 'GET').toUpperCase();

    req.query = Object.fromEntries(url.searchParams.entries());
    req.params = {};

    for (const route of this.routes) {
      if (route.method !== method) continue;

      const match = pathname.match(route.pattern);
      if (!match) continue;

      route.keys.forEach((key, i) => {
        req.params[key] = decodeURIComponent(match[i + 1]);
      });

      for (const handler of route.handlers) {
        await handler(req, res);
        if (res.writableEnded) return true;
      }
      return true;
    }

    return false;
  }
}

module.exports = Router;
