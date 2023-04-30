@group(0) @binding(0) var<storage, read_write> buffer: array<f32>;

@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> @builtin(position) vec4<f32> {
    let x = f32(i32(in_vertex_index) - 1);
    let y = f32(i32(in_vertex_index & 1u) * 2 - 1);
    return vec4<f32>(x, y, 0.0, 1.0);
}

@fragment
fn fs_main() -> @location(0) vec4<f32> {
    return vec4<f32>(1.0, 0.0, 0.0, 1.0);
}

@compute
@workgroup_size(1)
fn init(@builtin(global_invocation_id) global_id: vec3<u32>) {
    // buffer[0] = 1.0;
}

@compute
@workgroup_size(1)
fn k1() {
}

@compute
@workgroup_size(1)
fn k2() {
}

@compute
@workgroup_size(1)
fn k3() {
}

@compute
@workgroup_size(1)
fn k4() {
}

@compute
@workgroup_size(1)
fn psi() {
}
