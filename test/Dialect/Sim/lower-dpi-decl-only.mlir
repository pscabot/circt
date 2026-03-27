// RUN: circt-opt --sim-lower-dpi-func="declarations-only=true" %s | FileCheck %s

// CHECK-LABEL:  func.func private @foo(!llvm.ptr, i32) -> i32
// CHECK-NOT:    func.func @foo_wrapper
sim.func.dpi @foo(output arg0: i32, input %arg1: i32, return ret: i32)

// CHECK-LABEL:  func.func @bar_c_name
// CHECK-NOT:    func.func @bar_wrapper
sim.func.dpi @bar(output arg0: i32, input %arg1: i32, return ret: i32) attributes {verilogName="bar_c_name"}
func.func @bar_c_name(%arg0: !llvm.ptr, %arg1: i32) -> i32 {
  %0 = arith.constant 0 : i32
  func.return %0 : i32
}

// CHECK-LABEL:  func.func private @baz_c_name(!llvm.ptr, i32) -> i32
// CHECK-NOT:    func.func @baz_wrapper
sim.func.dpi @baz(output arg0: i32, input %arg1: i32, return ret: i32) attributes {verilogName="baz_c_name"}

// CHECK-NOT: sim.func.dpi

// Calls are updated to reference the C function declarations directly.
// CHECK-LABEL: hw.module @dpi_call
hw.module @dpi_call(in %clock : !seq.clock, in %enable : i1, in %in: i32,
          out o1: i32, out o2: i32, out o3: i32, out o4: i32) {
  // CHECK: sim.func.dpi.call @foo(%in) clock %clock
  // CHECK: sim.func.dpi.call @bar_c_name(%in)
  // CHECK: sim.func.dpi.call @baz_c_name(%in)
  %0, %1 = sim.func.dpi.call @foo(%in) clock %clock : (i32) -> (i32, i32)
  %2, %3 = sim.func.dpi.call @bar(%in) : (i32) -> (i32, i32)
  %4, %5 = sim.func.dpi.call @baz(%in) : (i32) -> (i32, i32)
  hw.output %0, %1, %2, %3 : i32, i32, i32, i32
}
