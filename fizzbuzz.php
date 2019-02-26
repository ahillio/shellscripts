<?php
function f() {
  for($i=1;$i<101;++$i){
    echo(($a=($i%3?"":'Fizz').($i%5?"":'Buzz'))?$a:$i).PHP_EOL;
  }
}
