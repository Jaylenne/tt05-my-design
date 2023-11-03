import cocotb
import numpy as np
import random
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

def gen(data):
    pulse_width = ''
    for pw in data:
        pulse_width += bin(pw)[2:].zfill(12)
    
    return pulse_width 

spi1_mosi = gen([random.randint(0, 2**12-1) for _ in range(8)])
# spi2_mosi = '01100000000'
spi2_mosi = '01110101101'

pw = [10, 15, 17, 20, 8, 6, 14, 30]

async def gen_pulse(dut, pw, i):
    # mimic the async signal in the chip
    await Timer(12, units='ns')
    dut.uio_in[i].value = 1
    await Timer(pw*50, units='ns')
    dut.uio_in[i].value = 0

async def spi1_write(dut):
    await RisingEdge(dut.clk)
    dut.ui_in[0].value = 1
    for i in range(96):
        await FallingEdge(dut.clk)
        dut.ui_in[2].value = int(spi1_mosi[95-i])
    await RisingEdge(dut.clk)
    dut.ui_in[0].value = 0

async def spi1_read(dut):
    pwm_all = []
    await RisingEdge(dut.clk)
    dut.ui_in[0].value = 1
    for i in range(8):
        pwm = ''
        for j in range(12):
            await RisingEdge(dut.clk)
            pwm = pwm + str(dut.uo_out[0].value)
        pwm_all.append(pwm[::-1])
    dut.ui_in[0].value = 0
    return pwm_all

async def spi2_write(dut):
    await RisingEdge(dut.clk)
    dut.ui_in[1].value = 1
    for i in range(11):
        await FallingEdge(dut.clk)
        dut.ui_in[3].value = int(spi2_mosi[10-i])
    await RisingEdge(dut.clk)
    dut.ui_in[1].value = 0

async def spi2_read(dut):
    knn_all = ''
    await RisingEdge(dut.clk)
    dut.ui_in[1].value = 1
    for i in range(16):
        await RisingEdge(dut.clk)
        knn_all = knn_all + str(dut.uo_out[1].value)
    dut.ui_in[1].value = 0
    return knn_all[::-1]

@cocotb.test()
async def test(dut):
    for i in range(8):
        print(spi1_mosi[(7-i)*12:(8-i)*12])
    dut._log.info("start")
    clock = Clock(dut.clk, 50, units="ns")
    cocotb.start_soon(clock.start())

    # reset
    dut._log.info("reset")
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Load data
    await spi1_write(dut)
    await ClockCycles(dut.clk, 10)
    await spi2_write(dut)
    await ClockCycles(dut.clk, 10)

    # Activate the 8 PWM signal
    await RisingEdge(dut.clk)
    dut.ui_in[4].value = 1
    await RisingEdge(dut.clk)
    dut.ui_in[4].value = 0

    for i in range(8):
        await cocotb.start(gen_pulse(dut, pw[i], i))

    #
    await ClockCycles(dut.clk, 2**13)

    # Read data
    pwm_all = await spi1_read(dut)
    knn_all = await spi2_read(dut)
    print(pwm_all)
    print(knn_all)




