
function setup(){
  createCanvas(800,600);
}

// the parameter at which x and y depends is usually taken as either t or symbol of theta
let t = 0;
function draw(){

  background('#fff');
  translate(width/2,height/2);
  stroke('#3182bd');
  strokeWeight(3);
  //loop for adding 100 lines
  for(let i = 0;i<100;i++){
    line(x1(t+i),y1(t+i),x2(t+i)+30,y2(t+i)+30);
  }
  t+=0.03;

  fill(255);
  textSize(40)
  text("分子细胞科学卓越创新中心生物信息平台", -width/2 + 10, height/2-20);
}

// function to change initial x co-ordinate of the line
function x1(t){
  return sin(t/10)*125+sin(t/20)*125+sin(t/30)*125;
}

// function to change initial y co-ordinate of the line
function y1(t){
  return cos(t/10)*125+cos(t/20)*125+cos(t/30)*125;
}

// function to change final x co-ordinate of the line
function x2(t){
  return sin(t/15)*125+sin(t/25)*125+sin(t/35)*125;
}

// function to change final y co-ordinate of the line
function y2(t){
  return cos(t/15)*125+cos(t/25)*125+cos(t/35)*125;
}
