(function () {
  var btn = document.querySelector('.nav-toggle');
  var nav = document.querySelector('.site-nav');
  if (!btn || !nav) return;
  btn.addEventListener('click', function () {
    var open = btn.getAttribute('aria-expanded') === 'true';
    btn.setAttribute('aria-expanded', String(!open));
    nav.classList.toggle('is-open');
  });
})();
