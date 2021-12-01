<?php
use PHPUnit\Framework\TestCase;

class CalculatorTest extends TestCase{

    public function testAdd(){
        $calculate = new App\Calculator();
        $result = $calculate->add(1, 2);

        $this->assertEquals(3, $result);
    }


}
