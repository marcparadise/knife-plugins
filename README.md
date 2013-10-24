
some knife plugins that might come in handy

dbi
===

This will let you look up specific nested key values in any valid data bag using a dotted key notation.

Given a data bag of the following:

```
{
   "k1" => "a",
   "k2" => [ "a" => { "hello" => "world" },
             "b", "c"],
   "k3" => {
              "sk2" => "world"
              "sk1" => "hello",
           }
}
```

Then the results for a given key would be as follows:

```
> knife dbi show k1
k1 = a
```

```
> knife dbi show k2.0 =>
k2.0
hello:
   world
```

```
> knife dbi.show k2.0.hello"
k2.0.hello = world
```

```
> knife dbi show k2.1
k2.1 = b
```

```
> knife dbi show k3
sk2:
    world
sk1:
    hello
```

```
> knife dbi show k2.10
ERROR: RuntimeError: failed at 'k2', index '10' out of range (max 2)
```

```
> knife dbi show k10
ERROR: RuntimeError: failed at (root), could not find value at 'k10'
```

```
> knife dbi show k3.sk1
k3.sk1 = hello
```


