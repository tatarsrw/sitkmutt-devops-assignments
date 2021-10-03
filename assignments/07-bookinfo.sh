# open ratings directory
cd ratings

# build docker image of mongodb and ratings
docker build -t mongodb .
docker build -t ratings .

# for run docker container mongodb with environment var + security
docker run -d --name mongodb -p 27017:27017 -v $(pwd)/databases:/docker-entrypoint-initdb.d -e MONGODB_ROOT_PASSWORD=CHANGEME -e MONGODB_USERNAME=ratings -e MONGODB_PASSWORD=CHANGEME -e MONGODB_DATABASE=ratings bitnami/mongodb:5.0.2-debian-10-r2

# for run docker container ratings with environment var + security
docker run -d --name ratings -p 8080:8080 --link mongodb:mongodb -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' -e SERVICE_VERSION=v2 -e MONGO_DB_USERNAME=ratings -e MONGO_DB_PASSWORD=CHANGEME ratings

# return and open details directory
cd ..
cd details

# build docker image of details
docker build -t details .

# for run docker container details with environment var
docker run -d --name details -p 8081:8081 -e ENABLE_EXTERNAL_BOOK_SERVICE=true -e DO_NOT_ENCRYPT=false details

# return and open reviews directory
cd ..
cd reviews

# build docker image of reviews
docker build -t reviews .

# for run docker container reviews with environment var and link to raings service
docker run -d --name reviews -p 8082:9080 --link ratings:ratings -e 'RATINGS_SERVICE=http://ratings:8080/' -e ENABLE_RATINGS=true reviews

# return and open productpage directory
cd ..
cd productpage

# build docker image of productpage
docker build -t productpage .

# for run docker container productpage with environment var and link to reviews, ratings, details service
docker run -d --name productpage -p 8083:9080 --link reviews:reviews --link ratings:ratings --link details:details -e 'RATINGS_HOSTNAME=http://ratings:8080/' -e 'DETAILS_HOSTNAME=http://details:8081/' -e 'REVIEWS_HOSTNAME=http://reviews:8082/' -e FLOOD_FACTOR=0 productpage