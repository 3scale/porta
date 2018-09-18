var htmlentities = (function(a) {
  function b(c) {
    var d = a.createElement("div");
    d.appendChild(a.createTextNode(c));
    c = d.innerHTML;
    d = null;
    return c
  }
  b.decode = function(c) {
    var d = a.createElement("div");
    d.innerHTML = c;
    c = d.innerText || d.textContent;
    d = null;
    return c
  };
  return (b.encode = b)
}(document));