# NetNutrition App

## What does the app do?

This app acts as a mobile interface for the Duke NetNutrition website that allows users to select foods they ate during the day, automatically populating all statistics like calories, carbs, etc. into HealthKit.

## Basic features

- Privacy settings with data
- Includes a listing of restaurants on campus
- For each restaurant, you can click on it and a list of foods served there that day is displayed
- Each food can be selected and its nutrition information will populate into HealthKit
- There is also a menu the user can access and scroll through showing the meals they have added historically

## Architecture

- Nutrition information comes from the Duke NetNutrition website on a real-time basis
- HealthKit permissions are required from the user and data will is whenever they add a meal
- User accounts/logins are not necessary
- There is minimal information to store locally within the app, the only thing to store is a historical listing of the users’ foods; nutrition data is stored in HealthKit

## Gallery

![](Images/CS207%20Project%20Slides-01.png)
![](Images/CS207%20Project%20Slides-02.png)
![](Images/CS207%20Project%20Slides-03.png)
![](Images/CS207%20Project%20Slides-04.png)
![](Images/CS207%20Project%20Slides-05.png)
![](Images/CS207%20Project%20Slides-06.png)
![](Images/CS207%20Project%20Slides-07.png)
![](Images/CS207%20Project%20Slides-08.png)
![](Images/CS207%20Project%20Slides-09.png)
![](Images/CS207%20Project%20Slides-10.png)
![](Images/CS207%20Project%20Slides-11.png)
