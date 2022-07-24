# NetNutrition App

## Final video demo Link

[Link](https://www.youtube.com/watch?v=TF5ex0PHpfA)

## What will the app do?

The app will act as a mobile interface for the Duke NetNutrition website that allows users to select foods they ate during the day, automatically populating all statistics like calories, carbs, etc. into HealthKit.

## Basic features and goals

- Privacy settings with data
- Will include a listing of restaurants on campus
- For each restaurant you can click on it and a list of foods served there that day will be displayed
- Each food can be selected and its nutrition information will populate into HealthKit
- There will also be a menu the user can access and scroll through showing the foods they have added historically

## Advanced features (if time allows)

- Provide pictures of the foods for aesthetic purposes
- Can provide a visual and statistical representation of a balanced diet, using user inputted information
- If we have a lot of time we can possibly find a way to automatically sync mobile orders to HealthKit from the Mobile Order app

## Architecture

- Nutrition information will ideally come from the Duke NetNutrition website on a daily basis
- HealthKit permissions will be required from the user and data will be written whenever they add a food
- User accounts/logins will not be necessary
- There will be minimal information to store locally within the app, the only thing to store is a historical listing of the users’ foods

## Storyboard wireframe
[Link](https://www.figma.com/file/TkatnfCQ871o28jZYsdUlV/CS207-Project?node-id=0%3A1)
