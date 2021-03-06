%%%%% value function iteration, two-dimensional grid over a,h
clear all;
close all;
clc;

%%%%%parameters%%%%%
beta=0.95;
sigma=1.5;
d=0.3;    %consumption share
eta=0.25; %transaction cost
b=0.5;
y1=1;
y2=1.5;
y=[y2,b];
pi=[0.97,0.03;0.5,0.5];
pi_inv=pi^1000;
pi_inv=pi_inv(:,1);

%%%%%set up the grids%%%
h_min=0.1;
h_max=5;
h_num=100;
h=linspace(h_min,h_max,h_num); %housing vector

a_min=-2;
a_max=5;
a_num=100; 
a=linspace(a_min,a_max,a_num); %assets vector
 
%%%initial guess for q
q_min=0.93;
q_max=1;


%%%%iterate over assets prices
aggsav=1;
a=repmat(a,[a_num 1 1]);
a=a(:);
while abs(aggsav)>=0.01
    q_guess=(q_min+q_max)/2;
    
    cons=bsxfun(@minus,a,q_guess*a');
    ho=repmat(h',[1 h_num 1]);
    hous=repmat(ho,h_num);
    cons=cons-hous-eta.*(abs(hous'-hous));
    cons=bsxfun(@plus,cons,permute(y,[1 3 2]));
    hous=repmat(hous,[1 1 2]);
    ret=((cons.^(1-d)).*(hous.^d)).^(1-sigma)./(1-sigma);
    ret(cons<0)=-Inf;
    
    v_guess=zeros(2,a_num*h_num);
    
    %%%value function iteration
    v_tol=1;
    while v_tol>=1e-03
        v_mat=ret+beta*repmat(permute(pi*v_guess,[3 2 1]),[a_num*h_num 1 1]);
        [vfn,pol_ind]=max(v_mat,[],2);
        vfn=permute(vfn,[3 1 2]);
        v_tol=abs(max(v_guess(:)-vfn(:)));
        v_guess=vfn;
    end
    pol_ind=permute(pol_ind,[3,1,2]);
    ab=a';
    pol_fn=ab(pol_ind);
    %%%%distribution
    Mu=ones (2,a_num*h_num); % Mu is the distribution for a(a,h,y)
    Mu=Mu/sum(Mu(:));
    
    mu_tol = 1;
   
   while mu_tol > 1e-05
    [emp_ind, a_ind,mass] = find(Mu); % find non-zero indices
    
    MuNew = zeros(size(Mu));
       for ii = 1:length(emp_ind)
        apr_ind = pol_ind(emp_ind(ii), a_ind(ii)); 
        MuNew(:, apr_ind) = MuNew(:, apr_ind) + ...
            (pi(emp_ind(ii), :) * mass(ii))';
       end

    mu_tol = max(abs(MuNew(:) - Mu(:)));
    
    Mu = MuNew ;
   end
    aggsav = sum( pol_fn(:) .* Mu(:) ); % Aggregate future assets

   if aggsav > 0 ;
    q_min = q_guess ;
    end ;
    if aggsav < 0;
    q_max = q_guess ;
    end ;
end


fa=linspace(a_min,a_max,a_num);
fh=h;
ho=repmat(h',[1 a_num 1]);
ho=ho(:);
hh=ho';
pol_hh=hh(pol_ind);
ze=[pol_fn(1,:);pol_hh(1,:)];
[hy,ax]=meshgrid(fh,fa);
h_plo_e=reshape(pol_hh(1,:),h_num,a_num);
h_plo_e=h_plo_e';
h_plo_u=reshape(pol_hh(2,:),h_num,a_num);
h_plo_u=h_plo_u';
figure (1) %policy function
surf(hy,ax,h_plo_e)
figure (2) %policy function
surf(hy,ax,h_plo_u)

a_plo_e=reshape(pol_fn(1,:),h_num,a_num);
a_plo_e=a_plo_e';
a_plo_u=reshape(pol_fn(2,:),h_num,a_num);
a_plo_u=a_plo_u';
figure (3)
surf(hy,ax,a_plo_e)    
figure (4)
surf(hy,ax,a_plo_u)    

mu_e=reshape(Mu(1,:),h_num,a_num);
mu_e=mu_e';
mu_u=reshape(Mu(2,:),h_num,a_num);
mu_u=mu_u';
figure (5)
surf(hy,ax,mu_e)    
figure (6)
surf(hy,ax,mu_u) 

