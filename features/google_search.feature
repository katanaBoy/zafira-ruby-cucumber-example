Feature: Google Searching

Background:
  Given the user opens a browser
  And the user navigates to "https://google.com/"

Scenario: Google shows "Guitar" related links
  When the user enters "Guitar" to the search bar
  Then links related to "Guitar" are shown

Scenario: Google shows "Cat" related links
  When the user enters "Cat" to the search bar
  Then links related to "Dog" are shown
  And links related to "Cat" are shown

Scenario: Google skips search
  When the user enters "Cat" to the search bar
  Then google skips searching
