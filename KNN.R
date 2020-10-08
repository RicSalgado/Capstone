library(ggplot2)
ggplot(mtcars, aes(x=mpg, y=hp, shape=cyl, color=cyl, size=cyl)) +
  geom_point()

Cylinders <- factor(mtcars$cyl)

ggplot(mtcars, aes(x=wt, y=mpg, color = Cylinders)) + geom_point() +   labs(title="Miles per gallon according to the weight",
                                                                            x="Weight (lb/1000)", y = "Miles/(US) gallon")
