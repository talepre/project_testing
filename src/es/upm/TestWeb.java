package es.upm;

/**
 * Created by Tale on 10.05.2016.
 */
import org.junit.*;
import org.openqa.selenium.*;
import org.openqa.selenium.chrome.ChromeDriver;

import static org.junit.Assert.assertEquals;


public class TestWeb {

    private WebDriver driver;

    @Before
    public void setUp() throws Exception {
        System.setProperty("webdriver.chrome.driver", "C:/Users/Tale/Tools/chromedriver.exe");
        driver = new ChromeDriver();
    }



    @Test
    public void testtestclass() throws Exception{
        //Open
        driver.get("http://www.ntnuidans.no/");
        //assertEquals("Wikipedia", driver.getTitle());
        //assertEquals("English", driver.findElement(By.cssSelector("strong")).getText());
        //driver.findElement(By.cssSelector("strong")).click();
        //assertEquals("Wikipedia", driver.getTitle());
        //The following will make the test fail (just as an example of a failing test)
        assertEquals("NTNUI Dans", driver.getTitle());

    }


    @After
    public void tearDown() throws Exception {
        driver.quit();
    }

}