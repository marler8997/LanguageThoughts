
# Problem

## Summary
```
x
if (some_condition1(x)) {
    if (some_condition2(x)) {
        ...
    }
}
```
if `some_condition2` is an equal or weaker version of `some_condition1`, then it the check should be removed by the compiler.

## Example
```

void func(int x)
    assume(x > 10)
{
    ...
}

if (x > 0) {
    func(x)  // the "assume" from func should already have been verified from the if statement above
}
```
