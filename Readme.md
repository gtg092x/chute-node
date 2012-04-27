# Chute

Chute is obviously API client for [Chute](http://getchute.com).

# Installation

`npm install chute`

# Usage

Check out **test/chute.test.coffee** for example code.

# Ideas about improving API

- All responses from API should have the same structure, like:

```
{
	"code": 12,
	"data": {},
	"success": true
}
```
- If sizes of two files are identical, it does not mean that they are the same. Real md5 must be calculated(POST /parcels)
- Sending correct md5 to *POST /parcels* fails request, while sending exact copy of file's size is ok

# Tests

Run tests with:
`mocha -t 10000`