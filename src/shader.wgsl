struct Params {
    width: u32,
    height: u32,
    x_0: f32,
    y_0: f32,
    sigma_0: f32,
    p_0: f32,
    delta_t: f32
}

struct ComplexNumber {
    real: f32,
    imaginary: f32
}

@group(0) @binding(0) var<storage, read_write> buffer: array<ComplexNumber>;
@group(0) @binding(1) var<uniform> params: Params;

@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> @builtin(position) vec4<f32> {
    let x = f32(i32(in_vertex_index & 2u) * 2 - 1);
    let y = f32(i32(in_vertex_index & 1u) * 4 - 1);
    return vec4<f32>(x, y, 0.0, 1.0);
}

@fragment
fn fs_main(@builtin(position) in: vec4<f32>) -> @location(0) vec4<f32> {
    let c = buffer[u32(in[0])+u32(in[1])*params.width];
    return vec4<f32>(c.real*c.real*params.sigma_0+c.imaginary*c.imaginary*params.sigma_0, 0.0, 0.0, 1.0);
}

@compute
@workgroup_size(1)
fn init(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let x = f32(global_id[0]);
    let y = f32(global_id[1]);
    let x_0 = params.x_0;
    let y_0 = params.y_0;
    let sigma_0 = params.sigma_0;
    let p_0 = params.p_0;
    buffer[global_id[0]+global_id[1]*params.width].real = pow(1.0/(2.0*3.1415*sigma_0*sigma_0),0.25)*exp(-((x-x_0)*(x-x_0)+(y-y_0)*(y-y_0))/(4.0*sigma_0*sigma_0))*cos(p_0*x);
    buffer[global_id[0]+global_id[1]*params.width].imaginary = pow(1.0/(2.0*3.1415*sigma_0*sigma_0),0.25)*exp(-((x-x_0)*(x-x_0)+(y-y_0)*(y-y_0))/(4.0*sigma_0*sigma_0))*sin(p_0*x);
}

fn prime(index: u32) -> ComplexNumber {
    return ComplexNumber(
        buffer[index + 1u].imaginary + buffer[index - 1u].imaginary + buffer[index + params.width].imaginary + buffer[index - params.width].imaginary - 4.0*buffer[index].imaginary,
        - buffer[index + 1u].real - buffer[index - 1u].real - buffer[index + params.width].real - buffer[index - params.width].real + 4.0*buffer[index].real
    );
}

@compute
@workgroup_size(1)
fn k1(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let psi_prime = prime(global_id[0]+global_id[1]*params.width);
    buffer[global_id[0]+global_id[1]*params.width+params.width*params.height]=ComplexNumber(psi_prime.real*params.delta_t,psi_prime.imaginary*params.delta_t);
}

@compute
@workgroup_size(1)
fn k2(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let k1_prime = prime(global_id[0]+global_id[1]*params.width+params.width*params.height);
    buffer[global_id[0]+global_id[1]*params.width+2u*params.width*params.height]=ComplexNumber(buffer[global_id[0]+global_id[1]*params.width+params.width*params.height].real+params.delta_t/0.5*k1_prime.real,buffer[global_id[0]+global_id[1]*params.width+params.width*params.height].imaginary+params.delta_t/0.5*k1_prime.imaginary);
}

@compute
@workgroup_size(1)
fn k3(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let k2_prime = prime(global_id[0]+global_id[1]*params.width+2u*params.width*params.height);
    buffer[global_id[0]+global_id[1]*params.width+3u*params.width*params.height]=ComplexNumber(buffer[global_id[0]+global_id[1]*params.width+params.width*params.height].real+params.delta_t/0.5*k2_prime.real,buffer[global_id[0]+global_id[1]*params.width+params.width*params.height].imaginary+params.delta_t/0.5*k2_prime.imaginary);
}

@compute
@workgroup_size(1)
fn k4(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let k3_prime = prime(global_id[0]+global_id[1]*params.width+3u*params.width*params.height);
    buffer[global_id[0]+global_id[1]*params.width+4u*params.width*params.height]=ComplexNumber(buffer[global_id[0]+global_id[1]*params.width+params.width*params.height].real+params.delta_t*k3_prime.real,buffer[global_id[0]+global_id[1]*params.width+params.width*params.height].imaginary+params.delta_t*k3_prime.imaginary);
}

@compute
@workgroup_size(1)
fn psi(@builtin(global_invocation_id) global_id: vec3<u32>) {
    buffer[global_id[0]+global_id[1]*params.width] = ComplexNumber(
        buffer[global_id[0]+global_id[1]*params.width].real+buffer[global_id[0]+global_id[1]*params.width+params.width*params.height].real/6.0+buffer[global_id[0]+global_id[1]*params.width+2u*params.width*params.height].real/3.0+buffer[global_id[0]+global_id[1]*params.width+3u*params.width*params.height].real/3.0+buffer[global_id[0]+global_id[1]*params.width+4u*params.width*params.height].real/6.0,
        buffer[global_id[0]+global_id[1]*params.width].imaginary+buffer[global_id[0]+global_id[1]*params.width+params.width*params.height].imaginary/6.0+buffer[global_id[0]+global_id[1]*params.width+2u*params.width*params.height].imaginary/3.0+buffer[global_id[0]+global_id[1]*params.width+3u*params.width*params.height].imaginary/3.0+buffer[global_id[0]+global_id[1]*params.width+4u*params.width*params.height].imaginary/6.0
    );
}
