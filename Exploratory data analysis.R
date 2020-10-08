library(readr)
library(dplyr)

#Importing the dataset
fashion_raw <- read.csv("fashion-mnist_train.csv")

library(tidyr)

#Below reshapes the data in order to gather pixels
pixels_get <- fashion_raw %>%
  head(60000) %>%
  rename(label = label) %>%
  mutate(instance = row_number()) %>%
  gather(pixel, value, -label, -instance) %>%
  tidyr::extract(pixel, "pixel", "(\\d+)", convert = TRUE) %>%
  mutate(pixel = pixel - 2,
         x = pixel %% 28,
         y = 28 - pixel %/% 28)

#Now it is proceeded to get the pixel spread
#How much gray there is in the images
library(ggplot2)

pixels_get %>%
  filter(instance <= 6) %>%
  ggplot(aes(x, y, fill = value)) +
  geom_tile() +
  facet_wrap(~ instance + label)

x_axis <- seq(0, 255, 20)

############################################
#Below produces summary statistics
#The mean position withing each label is obtained
pixel_sum <- pixels_get %>%
  group_by(x, y, label) %>%
  summarize(mean_value = mean(value)) %>%
  ungroup()

pixel_sum

#Plotting the average depiction of an article image
pixel_sum %>%
  ggplot(aes(x, y, fill = mean_value)) +
  geom_tile() +
  scale_fill_gradient2(low = "white", high = "black", mid = "gray", midpoint = 127.5) +
  facet_wrap(~ label, nrow = 2) +
  theme_void()

#############################################
#Handling images that are not easily classified
#Euclidean distance from each image to its label centroid (average image)
pixels_joined <- pixels_get %>%
  inner_join(pixel_sum, by = c("label", "x", "y"))

image_distances <- pixels_joined %>%
  group_by(label, instance) %>%
  summarize(euclidean_distance = sqrt(mean((value - mean_value) ^ 2)))

image_distances

Class <- image_distances$label
True_Labels <- c("T-shirt/top", "Trouser", "Pullover", "Dress", "Coat", "Sandal", "Shirt", "Sneaker", "Bag", "Ankle boot")

for(j in 1:60000){
  for(i in 0:9){
    if(Class[j] == i){Class[j] = True_Labels[i+1]}
    else {Class[j] = Class[j]}
  }
}
  
  
#Plotting the images variability for each label
ggplot(image_distances, aes(factor(Class), euclidean_distance, color = Class)) +
  geom_boxplot() +
  labs(x = "Clothing Item",
       y = "Euclidean distance to the clothing item centroid")

############################################
#Identifying the images that resemble their centroid the least
worst_inst <- image_distances %>%
  top_n(6, euclidean_distance) %>%
  mutate(number = rank(-euclidean_distance))

pixels_get %>%
  inner_join(worst_inst, by = c("label", "instance")) %>%
  ggplot(aes(x, y, fill = value)) +
  geom_tile(show.legend = FALSE) +
  scale_fill_gradient2(low = "white", high = "black", mid = "gray", midpoint = 127.5) +
  facet_grid(label ~ number) + 
  theme_void() +
  theme(strip.text = element_blank())