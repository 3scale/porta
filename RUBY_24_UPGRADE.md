# Upgrade to Ruby 2.4 changes and warnings

* [product-related] Fixnums are now Integer so it might break some XML response See commit 69363d43
* [gem] Think of replacing fakeweb, last release was in 2010
* Merge PR https://github.com/3scale/fakeweb/pull/1 and switch back in the Gemfile
