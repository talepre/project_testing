package com.example.tests;

import java.util.regex.Pattern;
import java.util.concurrent.TimeUnit;
import org.junit.*;
import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.*;
import org.openqa.selenium.*;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.support.ui.Select;

public class Login {
  private WebDriver driver;
  private String baseUrl;
  private boolean acceptNextAlert = true;
  private StringBuffer verificationErrors = new StringBuffer();

  @Before
  public void setUp() throws Exception {
    driver = new FirefoxDriver();
    baseUrl = "https://online.ntnu.no/";
    driver.manage().timeouts().implicitlyWait(30, TimeUnit.SECONDS);
  }

  @Test
  public void testLogin() throws Exception {
    driver.get(baseUrl + "/");
    driver.findElement(By.xpath("//nav[@id='mainnav']/div/ul[3]/li/a")).click();
    driver.findElement(By.linkText("Logg ut")).click();
    driver.findElement(By.xpath("//nav[@id='mainnav']/div/ul[3]/li/a")).click();
    driver.findElement(By.id("id_username")).clear();
    driver.findElement(By.id("id_username")).sendKeys("talep");
    driver.findElement(By.id("id_password")).clear();
    driver.findElement(By.id("id_password")).sendKeys("OnlineErlang");
    driver.findElement(By.cssSelector("button.btn.btn-primary")).click();
    driver.findElement(By.xpath("//nav[@id='mainnav']/div/ul[3]/li/a")).click();
    driver.findElement(By.linkText("Logg ut")).click();
    driver.findElement(By.xpath("//nav[@id='mainnav']/div/ul[3]/li/a")).click();
    driver.findElement(By.id("id_username")).clear();
    driver.findElement(By.id("id_username")).sendKeys("hehe");
    driver.findElement(By.id("id_password")).clear();
    driver.findElement(By.id("id_password")).sendKeys("hehe");
    driver.findElement(By.cssSelector("button.btn.btn-primary")).click();
    driver.findElement(By.cssSelector("button.btn.btn-primary")).click();
    driver.findElement(By.cssSelector("button.btn.btn-primary")).click();
    driver.findElement(By.id("password")).clear();
    driver.findElement(By.id("password")).sendKeys("hehe");
    driver.findElement(By.cssSelector("button.btn.btn-success")).click();
    driver.findElement(By.id("username")).click();
    driver.findElement(By.id("username")).clear();
    driver.findElement(By.id("username")).sendKeys("talep");
    driver.findElement(By.id("password")).clear();
    driver.findElement(By.id("password")).sendKeys("OnlineErlang");
    driver.findElement(By.cssSelector("button.btn.btn-success")).click();
  }

  @After
  public void tearDown() throws Exception {
    driver.quit();
    String verificationErrorString = verificationErrors.toString();
    if (!"".equals(verificationErrorString)) {
      fail(verificationErrorString);
    }
  }

  private boolean isElementPresent(By by) {
    try {
      driver.findElement(by);
      return true;
    } catch (NoSuchElementException e) {
      return false;
    }
  }

  private boolean isAlertPresent() {
    try {
      driver.switchTo().alert();
      return true;
    } catch (NoAlertPresentException e) {
      return false;
    }
  }

  private String closeAlertAndGetItsText() {
    try {
      Alert alert = driver.switchTo().alert();
      String alertText = alert.getText();
      if (acceptNextAlert) {
        alert.accept();
      } else {
        alert.dismiss();
      }
      return alertText;
    } finally {
      acceptNextAlert = true;
    }
  }
}
