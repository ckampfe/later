# Later

A "dead man's switch", that will make a private file public if the switch is not triggered
before the given time.

```
###
### upload a file, get back the hash of the file, public and private tokens for identification and authentication
###
POST http://localhost:4000/files
Content-type: application/octet-stream

< /Users/clark/code/later/comtruise.jpg

#=>
# {
#   "hash": "83744630ef6808874f2008459530f46d8ec63b0dea95b7719c55165d442deef91393319c3ac58ceb48389f798ab6402ea1248383df245a1c8da7f56b947539bb",
#   "private_token": "7166948b5b77f650dd5be2f6c2bc18755925293c2df1a91f60586d4bcb92d9094d96813844cdf9d1a8017adfa8a21b6b538480904019a26c8388cd14e9a27b95",
#   "public_token": "f41b1ed00744fcd4e6d7448a1d398cb989e5fbdee4e7779cd2d9ac8f3b563aab33d6c5401f1aba906b8dd24eaf9571e2ebedcf5b98e93c6b8b53b5f5dd0802ba"
# }

###
### try to get with public token, but it is not available
###
GET http://localhost:4000/files/f41b1ed00744fcd4e6d7448a1d398cb989e5fbdee4e7779cd2d9ac8f3b563aab33d6c5401f1aba906b8dd24eaf9571e2ebedcf5b98e93c6b8b53b5f5dd0802ba
#=> not found

###
### We set a cron that will make the file public if it is not kept private before the 15th minute of every hour
###
PUT http://localhost:4000/files/f41b1ed00744fcd4e6d7448a1d398cb989e5fbdee4e7779cd2d9ac8f3b563aab33d6c5401f1aba906b8dd24eaf9571e2ebedcf5b98e93c6b8b53b5f5dd0802ba/release_on
Content-type: application/json

{
  "private_token":"7166948b5b77f650dd5be2f6c2bc18755925293c2df1a91f60586d4bcb92d9094d96813844cdf9d1a8017adfa8a21b6b538480904019a26c8388cd14e9a27b95",
  "cron":"15 * * * *"
}
#=> ok

###
### we ask for info and get the next_run_time UTC
###
POST http://localhost:4000/files/f41b1ed00744fcd4e6d7448a1d398cb989e5fbdee4e7779cd2d9ac8f3b563aab33d6c5401f1aba906b8dd24eaf9571e2ebedcf5b98e93c6b8b53b5f5dd0802ba/info
Content-type: application/json

{
  "private_token":"7166948b5b77f650dd5be2f6c2bc18755925293c2df1a91f60586d4bcb92d9094d96813844cdf9d1a8017adfa8a21b6b538480904019a26c8388cd14e9a27b95"
}

#=>
# {
#   "next_run_time": "2019-11-22T03:15:00Z"
# }

###
### file is still not found
### 
GET http://localhost:4000/files/f41b1ed00744fcd4e6d7448a1d398cb989e5fbdee4e7779cd2d9ac8f3b563aab33d6c5401f1aba906b8dd24eaf9571e2ebedcf5b98e93c6b8b53b5f5dd0802ba
#=> not found

###
### file is now available
###
GET http://localhost:4000/files/f41b1ed00744fcd4e6d7448a1d398cb989e5fbdee4e7779cd2d9ac8f3b563aab33d6c5401f1aba906b8dd24eaf9571e2ebedcf5b98e93c6b8b53b5f5dd0802ba
#=>
# {
#   "file_location": "/tmp/83744630ef6808874f2008459530f46d8ec63b0dea95b7719c55165d442deef91393319c3ac58ceb48389f798ab6402ea1248383df245a1c8da7f56b947539bb",
#   "hash": "83744630ef6808874f2008459530f46d8ec63b0dea95b7719c55165d442deef91393319c3ac58ceb48389f798ab6402ea1248383df245a1c8da7f56b947539bb",
#   "public_token": "public_token",
#   "uploaded_at": "2019-11-22T03:08:52.369709Z"
# }
```

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
