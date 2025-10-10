import cocotb
from cocotb.triggers import FallingEdge, Timer
import logging
import math 
import hashlib
import random 

BB=64 

def get_cmd(valid=True, conf=False, start=False, data=False, last=False):
    check = [conf, start, data, last]
    assert(sum(check) <= 1) # check one hot 0
    cmd = 0
    if (start):
        cmd = 1;
    elif (data):
        cmd = 2
    elif (last):
        cmd = 3
    return valid | cmd << 1
    
async def generate_clock(dut):
    while(1):
        dut.clk.value = 0
        await Timer(1, unit="ns")
        dut.clk.value = 1
        await Timer(1, unit="ns")

async def write_config(dut, kk, nn, ll):
    dut.uio_in.value = 1 # valid 1, cmd = 0
    # kk (8b), nn (8b), ll (64b)
    dut.ui_in.value = kk
    await Timer(2, unit="ns")
    dut.ui_in.value = nn
    await Timer(2, unit="ns")
    for i in range(0,8):
        dut.ui_in.value = (ll >> 8*i) & 0xff
        cocotb.log.debug("writing ll %s",dut.ui_in.value)
        await Timer(2, unit="ns")
    dut.uio_in.value = 0

async def write_data_in(dut, block=b'', start=False, last=False):
    cocotb.log.info("block len %s", len(block))
    assert(len(block) == BB )
    #todo add ready signal 
    for i in range(0,BB): 
        dut.uio_in.value = get_cmd(data=True)
        if (i == 0) and start: 
            dut.uio_in.value = get_cmd(start=True)
        if (i == BB - 1) and last: 
            dut.uio_in.value = get_cmd(last=True)
        dut.ui_in.value = block[i]
        await Timer(2, unit="ns")

# lengths are in bytes
async def send_data_to_hash(dut, key=b'', data=b''):
    cocotb.log.info("write_data key(%s) data(%s)", len(key), len(data))
    start = True
    last = False

    assert(len(data) > 0) 
    if len(key) > 0:
        assert (len(key) <= BB/32)
        tmp = key.ljust(BB, b'\x00')
        cocotb.log.debug("key %s", len(tmp))
        await write_data_in(dut, tmp, start, False) 
        start = False

    block_count = math.ceil(len(data)/BB)
    padded_size = block_count * BB
    padded_data = data.ljust(padded_size, b'\x00')
    cocotb.log.debug("data %s", len(padded_data))
    for i in range(0, block_count):
        if ( i == block_count - 1): 
            last=True
        await write_data_in(dut, padded_data[i*BB:((i+1)*BB)], start, last)
        start = False
    dut.uio_in.value = 0

async def test_hash(dut, kk, nn, ll, key, data):
    h = hashlib.blake2s(data, digest_size=nn, key=key)
    cocotb.log.info("data(%s): %s", ll, data.hex())
    cocotb.log.info("hash(%s): %s", nn, h.hexdigest())
    await write_config(dut, kk, nn , ll)
    await Timer(2, unit="ns")
    await send_data_to_hash(dut, key, data)
    await Timer(250, unit="ns")
   

async def test_random_hash(dut):
    ll = random.randrange(65)
    nn = random.randrange(1,33)
    kk=0
    key = random.randbytes(kk)
    data = random.randbytes(ll)
    await test_hash(dut, kk, nn, ll, b'', data)

async def rst(dut, ena=1):
    dut.rst_n.value = 0
    cocotb.start_soon(generate_clock(dut))  # run the clock "in the background" 
    await Timer(4, unit="ns")
    # set default io
    dut.uio_in.value = 0
    dut.ena.value = 0
    await Timer(random.randrange(1,10), unit="ns")
    await FallingEdge(dut.clk)  
    dut.rst_n.value = 1
    dut.ena.value = ena
    await Timer(random.randrange(1,10), unit="ns")
    await FallingEdge(dut.clk)



# check internal signals are not toogling when slice is dissabled
# used to reduce dynamic power usage
@cocotb.test()
async def dissable_test(dut):
    await rst(dut, ena=0)
    uo_out = dut.uo_out.value # stable check, doesn't matter if it is X
    c = random.randrange(10, 50)
    for i in range(0, c):
        assert(dut.uo_out.value == uo_out)
        assert(dut.uio_out.value == 0)
        Timer(2, unit="ns")
   
# blake2 spec, appandix C blake2s test vector
@cocotb.test()
async def hash_spec_test(dut):
    await rst(dut)
    await test_hash(dut, 0, 32, 3, b'', b"abc")

@cocotb.test()
async def hash_test(dut):
    await rst(dut)
    await Timer(4, unit="ns")
    await test_random_hash(dut)
    #await send_data_to_hash(dut, b'\x01', b'\xbe\xef\xbe\xef')
