xquery version "3.0";

module namespace app="http://exist-db.org/apps/recipes/templates";

import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://exist-db.org/apps/recipes/config" at "config.xqm";

(:~
 :  Normalize ingredient name
 :)
declare function app:normIngName($ingName) as xs:string
{
  (: remove parenthesized expression that may begin string, e.g. in
     "(10 ozs) Rotel diced tomatoes":)
  let $normedName := replace($ingName, "^\(.*?\)\s*", "")

  (: convert to all lower-case :)
  let $normedName := lower-case($normedName)

  (: replace multiple spaces with a single one :)
  let $normedName := normalize-space($normedName) 

  return $normedName
};

(:~
 :  Normalize a list of ingredient names
 :)
declare function app:normIngList($ingList) as item()*
{
  for $ingName in $ingList
    return app:normIngName($ingName)
};

(:~
 : List recipes by ingredient
 :)
declare function app:byIngredient($node as node(), $model as map(*))
{
  let $docs := collection('apps/recipes/cookbook/xml')
  let $normedIngNames := app:normIngList($docs//ing/item)
  let $ingredients := distinct-values($normedIngNames)
  
  return (
      <div class="alert alert-success">
        <p><i><b>{count($ingredients)}</b> unique ingredients in <b>{count($docs)}</b> recipes</i></p>
      </div>,
  
      for $ingr in $ingredients
      where $ingr != ""
      order by $ingr empty least
      return (
        <h4>{$ingr} <span class="badge" style="float: right">{count(for $d in $docs, $i in $d//item where app:normIngName($i) = $ingr return $i)}</span></h4>,
        <ol>
        {
          for $doc in $docs, $i in $doc//item
          where app:normIngName($i) = $ingr
          return
             <li>
                <a href="{substring-after(document-uri($doc), concat($config:app-root, "/"))}">{$doc/recipeml/recipe/head/title/text()}</a>
             </li>
        }
        </ol>
      )
  )
};

(:~
 : List recipes by category
 :)
declare function app:byCategory($node as node(), $model as map(*))
{
  let $docs := collection('apps/recipes/cookbook/xml')
  let $normedCatNames := app:normIngList($docs//cat)
  let $categories := distinct-values($normedCatNames)
  
  return (
      <div class="alert alert-success">
        <p><i><b>{count($categories)}</b> unique categories in <b>{count($docs)}</b> recipes</i></p>
      </div>,
  
      for $cat in $categories
      where $cat != ""
      order by $cat empty least
      return (
        <h4>{$cat} <span class="badge" style="float: right">{count(for $d in $docs, $c in $d//cat where app:normIngName($c) = $cat return $c)}</span></h4>,
        <ol>
        {
          for $doc in $docs, $c in $doc//cat
          where app:normIngName($c) = $cat
          return
             <li>
                <a href="{substring-after(document-uri($doc), concat($config:app-root, "/"))}">{$doc/recipeml/recipe/head/title/text()}</a>
             </li>
        }
        </ol>
      )
  )
};

(:~
 : Timestamp
 :)
declare function app:timestamp($node as node(), $model as map(*))
{
    <span> {current-date()} at {current-time()} </span>
};

(:~
 : Description
 :)
declare function app:description($node as node(), $model as map(*))
{
    <span> {$config:repo-descriptor/repo:description/text()} </span>
};
