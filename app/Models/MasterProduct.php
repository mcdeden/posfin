<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterProduct extends Model
{
    protected $table='master_products';
    public $incrementing = false;

    protected $fillable = [
        'id', 'name','short_name','bank_id','insurance_id'
    ];

    function bank() {
        return $this->belongsTo('App\Models\MasterBank');
    }

    function insurance() {
        return $this->belongsTo('App\Models\MasterInsurances');
    }
}
