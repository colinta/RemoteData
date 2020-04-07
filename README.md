# RemoteData

A partial port of [RemoteData](https://github.com/krisajenkins/remotedata).

To understand it best, I recommend the blog post: http://blog.jenkster.com/2016/06/how-elm-slays-a-ui-antipattern.html

But the long and short of this data type is that it more closely models an apps
network request life cycle:

- `.notAsked`
- `.loading`
- `.success(T)`
- `.failure(Error)`

You can use `get()` similar to how you use it with `Result`, except it returns an optional if the data is `notAsked` or `loading`

```swift
do {
    if let data = try data.get() {
        // data was successfully fetched
    }
    else {
        // not asked or still loading
    }
} catch { error }
```

You can also `map` the data on `.success`, or `mapError` can map the error to another error, or `catch` will map the error to a `success` (or `rethrow` to keep the error).  Finally you can chain any number of `andMap(remotedata)` and if all the data is `.success` you will get a tuple built up from each successive call – read on for clarification.

To make `andMap` really useful, I am including `untuple`, which can take the results of many `andMap` chains (up to 10) and puts the result into one "flattened" tuple.

```swift
var rd1: RemoteData<A>
var rd2: RemoteData<B>
var rd3: RemoteData<C>

var rdAll: RemoteData<(A, B, C)> {
    rd1
        .andMap(rd2)
        .andMap(rd3)
        // type is now RemoteData<((A, B), C)>, which is a bit unwieldy
        .map(untuple)
        // equivalent to .map { ((a, b), c) in (a, b, c) }
        // type is now RemoteData<(A, B, C)>
}
```

Any failure will surface immediately, regardless of the other values ("leftmost" error wins). Next, any values `.loading` will result in a value of `.loading`, similarly for `.notAsked` (a combination of `notAsked` and `success` is nonsensical, but results in a final result of `notAsked`).  All values must be `.success` for the final result to be `.success`.
